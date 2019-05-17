
float c = 1.5;

bool loop(int n, string m) {
	while (n > m) {
        n--;
    }
    return true;
}

int main() {
    int x;
    int i;
    int a = 5;
    string y = "She is a girl";

    print(y);

    if (a > 10) {
        x += a;
        print(x);
    } else {
        x = a % 10 + 10 * 7;
        print(x);
    }
    print("Hello World");

    return 0; 
}
