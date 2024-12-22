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
  subscribeToStockfishOutput,
  subscribeToStockfishError,
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

useEffect(() => {
  const unsubscribe = subscribeToStockfishError((error) => {
    console.log('Stockfish Error:', error);
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

If you need to upgrade Stockfish source files, create a folder **stockfish** inside **cpp** folder, copy the **src** folder from the stockfish sources into the new **stockfish folder**. Also you need to make some more adaptive works :

#### Adapting streams

- copy the **cpp/fixes** folder inside the **cpp/stockfish** folder

- replace all calls to `cout << #SomeContent# << endl` by `fakeout << #SomeContent# << fakeendl` (And ajust also calls to `cout.rdbuf()` by `fakeout.rdbuf()`) **But do not replace calls to sync_cout**.
- copy folder **cpp/fixes** inside the **stockfish** folder
- add include to **../fixes/fixes.h** in all related files (and adjust the include path accordingly)
- proceed accordingly for `cin` : replace by `fakein`
- and the same for `cerr`: replace by `fakeerr`
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

#### Adapting NNUE

In file **CMakeLists.txt** replace the names of big and small NNUE by the ones you can find in file **cpp/stockfish/src/evaluate.h**

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
