package a1;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import static org.junit.jupiter.api.Assertions.*;

public class CalculadoraTest {
    static Calculadora calculadora;

    @BeforeAll 
    static void arrange(){
        // Arrange 
        calculadora = new Calculadora();
    }

    @Test 
    public void deveSomarDoisNumeros(){
        // Action 
        int soma = calculadora.somar(2, 3);

        // Assert
        assertEquals(5, soma);
    }

    @Test 
    public void deveSubtrairDoisNumeros(){
        // Assert
        assertEquals(6, calculadora.subtrair(10, 4));
    }

    @Test 
    public void deveMultiplicarDoisNumeros(){
        // Assert
        assertEquals(42, calculadora.multiplicar(6, 7));
    }

    @Test 
    public void deveDividirDoisNumeros(){
        // Assert
        assertEquals(42, calculadora.multiplicar(6, 7));        
        assertThrows(ArithmeticException.class, () -> calculadora.dividir(10,0),
                "Não é permitido dividir por zero!");
    }

    @ParameterizedTest 
    @CsvSource ({
    "1, 1, 2", "3, 7, 10", "-5, 5, 0"})
    public void deveSomarParametrizado(int num1, int num2, int numEsperado){
        // Action 
        int soma = calculadora.somar(num1, num2);

        // Assert
        assertEquals(numEsperado, soma);
    }
    
}
