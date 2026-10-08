package a1;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.anyInt;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;
public class PedidoServiceTest {
    // Q6
    @Test 
    void deveColocarPedidoECapturarEnvioDeEmail(){
        // Arrange
        EmailService emailServiceMock = mock(EmailService.class);
        EstoqueService estoqueService = mock(EstoqueService.class);

        PedidoService pedidoService = 
            new PedidoService(emailServiceMock, estoqueService);

        // Double / Dublê
        when(emailServiceMock.enviarEmail(anyString(), 
                                          anyString())).thenReturn(true);
        when(estoqueService.verificarEstoque(anyString(), anyInt())).thenReturn(true);

        // Action
        String resultado = pedidoService.finalizarPedido(
            "c@e.com", "SKU-1", 1);

        // Assert
        assertEquals("sucesso", resultado);
        verify(emailServiceMock, times(1)).enviarEmail(
                 "c@e.com", "Pedido finalizado: SKU-1");
    }

    // Q7
    @Test
    void deveColocarPedidoEDarFalsoNoEnvioDeEmail(){
        // Arrange
        EmailService emailMock = mock(EmailService.class);
        EstoqueService estoqueMock = mock(EstoqueService.class);

        when(estoqueMock.verificarEstoque(anyString(), anyInt())).thenReturn(true);
        when(emailMock.enviarEmail(anyString(), anyString())).thenReturn(false);

        PedidoService pedidoService = new PedidoService(emailMock, estoqueMock);

        // Action 
        String resultado = pedidoService.finalizarPedido(
            "c@e.com", "SKU-1", 1);

        // Assertions
        assertEquals("falhou", resultado, 
        "Pedido deve retornar falho quando email falha");
    }   
}
