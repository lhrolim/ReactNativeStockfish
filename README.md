# @loloof64/react-native-stockfish

Use stockfish chess engine in your React Native application

Be careful : though IOS code has been implemented, it has not been tested.
You may want to adjust the code to make it pass. (I'm open to pull request)

## Installation

```sh
npm install @loloof64/react-native-stockfish
```

## Usage

```js
import {
  stockfishLoop,
  sendCommandToStockfish,
  subscribeToStockfishOutput
  stopStockfish,
} from '@loloof64/react-native-stockfish';

// ...

stockfishLoop();

// ...

useEffect(() => {
  const unsubscribe = subscribeToStockfishOutput((output) => {
    console.log('Stockfish Output:', output);
  });

  return () => unsubscribe();
}, []);

// ...

sendCommandToStockfish('go movetime 1000');

// ...

stopStockfish();
```

## Contributing

See the [contributing guide](CONTRIBUTING.md) to learn how to contribute to the repository and the development workflow.

### Changing Stockfish source files

If you need to upgrade Stockfish source files, you need to make some more adaptive works :

- replace all calls to `cout << #SomeContent# << endl` by `fakeout << #SomeContent# << fakeendl` (And ajust also calls to `cout.rdbuf()` by `fakeout.rdbuf()`)
- add include to **../../fixes/fixes.h** in all related files (and adjust the include path accordingly)
- proceed accordingly for `cin`.
- in **misc.h** replace

```cpp
#define sync_cout std::cout << IO_LOCK
#define sync_endl std::endl << IO_UNLOCK
```

with

```cpp
#define sync_cout fakeout << IO_LOCK
#define sync_endl fakeendl << IO_UNLOCK
```

and include **../../fixes/fixes.h**

- change the NNUE defined in **android/CmakeLists.txt** by the one defined in **stockfish/src/evaluate.h**

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
