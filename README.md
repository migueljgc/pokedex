# pokedex

# Ejercicios 

# fibonacci

int fobonacci(int n, {Map<int, int>? memo}) {
  if (memo == null) {
    memo = {};
  }

  if (memo.containsKey(n)) {
    return memo[n]!;
  }

  if (n <= 2) {
    return 1;
  }

  memo[n] = fobonacci(n - 1, memo: memo) + fobonacci(n - 2, memo: memo);
  return memo[n]!;
}

void main() {
  print(fobonacci(50));
}

# palindromo

bool Palindromo(String cadena) {
  // Se eliminan los espacios en blanco
  cadena = cadena.replaceAll(" ", "");
  // Se convierte la cadena a minúsculas
  cadena = cadena.toLowerCase();

  return cadena == cadena.split('').reversed.join('');
}

void main() {
  print(Palindromo("Anita lava la tina"));
}

