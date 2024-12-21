import {
  Text,
  View,
  TextInput,
  Button,
  ScrollView,
  StyleSheet,
} from 'react-native';
import { useEffect, useState } from 'react';
import {
  stockfishLoop,
  subscribeToStockfishOutput,
  sendCommandToStockfish,
  stopStockfish,
} from '@loloof64/react-native-stockfish';

function useStockfishOutput() {
  const [stockfishOutput, setStockfishOutput] = useState('');

  useEffect(() => {
    const unsubscribe = subscribeToStockfishOutput((output) => {
      setStockfishOutput((prev) => prev + output);
    });

    return () => unsubscribe();
  }, []);

  return stockfishOutput;
}

export default function App() {
  const [command, setCommand] = useState('');

  useEffect(() => {
    stockfishLoop();
    sendCommandToStockfish('uci');

    return () => {
      stopStockfish();
    };
  }, []);

  const stockfishOutput = useStockfishOutput();

  return (
    <View style={styles.container}>
      <View style={styles.inputContainer}>
        <Text>Command: </Text>
        <TextInput
          style={styles.inputControl}
          placeholder="Your command"
          value={command}
          onChangeText={setCommand}
        />
        <Button
          title="Send"
          onPress={() => {
            sendCommandToStockfish(command);
            setCommand('');
          }}
        />
      </View>
      <ScrollView>
        <Text>{stockfishOutput}</Text>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    alignItems: 'center',
    justifyContent: 'flex-start',
  },
  inputContainer: {
    flexDirection: 'row',
    alignSelf: 'flex-start',
    alignItems: 'center',
    justifyContent: 'flex-start',
  },
  inputControl: {
    flex: 1,
  },
});
