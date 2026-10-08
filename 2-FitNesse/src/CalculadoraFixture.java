import a1.Calculadora;

public class CalculadoraFixture {
    private Calculadora calculadora;
    private int numero1;
    private int numero2;
    private int resultado;

    public CalculadoraFixture() {
        this.calculadora = new Calculadora();
    }

    public void setNumero1(int numero1) {
        this.numero1 = numero1;
    }

    public void setNumero2(int numero2) {
        this.numero2 = numero2;
    }

    public int somar() {
        this.resultado = calculadora.somar(numero1, numero2);
        return resultado;
    }

    public int getResultado() {
        return resultado;
    }

    public int subtrair() {
        this.resultado = calculadora.subtrair(numero1, numero2);
        return resultado;
    }

    public int multiplicar() {
        this.resultado = calculadora.multiplicar(numero1, numero2);
        return resultado;
    }

    public double dividir() {
        this.resultado = (int) calculadora.dividir(numero1, numero2);
        return resultado;
    }
}
