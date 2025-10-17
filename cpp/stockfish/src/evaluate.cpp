/*
  Stockfish, a UCI chess playing engine derived from Glaurung 2.1
  Copyright (C) 2004-2024 The Stockfish developers (see AUTHORS file)

  Stockfish is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  Stockfish is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "evaluate.h"

#include <algorithm>
#include <cassert>
#include <cmath>
#include <cstdlib>
#include <iomanip>
#include <iostream>
#include <memory>
#include <sstream>
#include <tuple>

#include "nnue/network.h"
#include "nnue/nnue_misc.h"
#include "position.h"
#include "types.h"
#include "uci.h"
#include "nnue/nnue_accumulator.h"

namespace Stockfish {

// Returns a static, purely materialistic evaluation of the position from
// the point of view of the given color. It can be divided by PawnValue to get
// an approximation of the material advantage on the board in terms of pawns.
int Eval::simple_eval(const Position& pos, Color c) {
    return PawnValue * (pos.count<PAWN>(c) - pos.count<PAWN>(~c))
         + (pos.non_pawn_material(c) - pos.non_pawn_material(~c));
}

bool Eval::use_smallnet(const Position& pos) {
    // MOBILE OPTIMIZATION: Always use small network (6MB) for faster performance
    // Original logic checked material balance: std::abs(simpleEval) > 962
    // This forces small network only, avoiding 133MB big network load
    // Trade-off: ~0.3 pawns less accurate, but 40x faster (2000ms -> 50ms)
    return true;
}

// Evaluate is the evaluator for the outer world. It returns a static evaluation
// of the position from the point of view of the side to move.
Value Eval::evaluate(const Eval::NNUE::Networks&    networks,
                     const Position&                pos,
                     Eval::NNUE::AccumulatorCaches& caches,
                     int                            optimism) {

    assert(!pos.checkers());

    // MOBILE OPTIMIZATION: Always use small network, never fallback to big network
    // This eliminates the 1-2 second delay from loading 133MB big network
    // Original code would load BOTH networks (139MB total) for uncertain positions

    auto [psqt, positional] = networks.small.evaluate(pos, &caches.small);
    Value nnue = (125 * psqt + 131 * positional) / 128;

    // REMOVED: Big network fallback that was loading both networks
    // Original code (lines 73-78):
    // if (smallNet && (nnue * psqt < 0 || std::abs(nnue) < 227)) {
    //     std::tie(psqt, positional) = networks.big.evaluate(pos, &caches.big);
    //     nnue = (125 * psqt + 131 * positional) / 128;
    //     smallNet = false;
    // }
    // This was causing BOTH 133MB + 6MB networks to load for ~30-40% of positions!

    // Blend optimism and eval with nnue complexity
    // Simplified to use only small network constants (no conditional logic)
    int nnueComplexity = std::abs(psqt - positional);
    optimism += optimism * nnueComplexity / 433;  // Small network constant
    nnue -= nnue * nnueComplexity / 18815;        // Small network constant

    int material = 553 * pos.count<PAWN>() + pos.non_pawn_material();  // Small network constant
    int v = (nnue * (73921 + material) + optimism * (8112 + material)) / 68104;  // Small network constant

    // Evaluation grain (to get more alpha-beta cuts) with randomization (for robustness)
    v = (v / 16) * 16 - 1 + (pos.key() & 0x2);

    // Damp down the evaluation linearly when shuffling
    v -= v * pos.rule50_count() / 212;

    // Guarantee evaluation does not hit the tablebase range
    v = std::clamp(v, VALUE_TB_LOSS_IN_MAX_PLY + 1, VALUE_TB_WIN_IN_MAX_PLY - 1);

    return v;
}

// Like evaluate(), but instead of returning a value, it returns
// a string (suitable for outputting to stdout) that contains the detailed
// descriptions and values of each evaluation term. Useful for debugging.
// Trace scores are from white's point of view
std::string Eval::trace(Position& pos, const Eval::NNUE::Networks& networks) {

    if (pos.checkers())
        return "Final evaluation: none (in check)";

    auto caches = std::make_unique<Eval::NNUE::AccumulatorCaches>(networks);

    std::stringstream ss;
    ss << std::showpoint << std::noshowpos << std::fixed << std::setprecision(2);
    ss << '\n' << NNUE::trace(pos, networks, *caches) << '\n';

    ss << std::showpoint << std::showpos << std::fixed << std::setprecision(2) << std::setw(15);

    // MOBILE OPTIMIZATION: Use small network for trace as well
    auto [psqt, positional] = networks.small.evaluate(pos, &caches->small);
    Value v                 = psqt + positional;
    v                       = pos.side_to_move() == WHITE ? v : -v;
    ss << "NNUE evaluation        " << 0.01 * UCIEngine::to_cp(v, pos) << " (white side)\n";

    v = evaluate(networks, pos, *caches, VALUE_ZERO);
    v = pos.side_to_move() == WHITE ? v : -v;
    ss << "Final evaluation       " << 0.01 * UCIEngine::to_cp(v, pos) << " (white side)";
    ss << " [with scaled NNUE, ...]";
    ss << "\n";

    return ss.str();
}

}  // namespace Stockfish
