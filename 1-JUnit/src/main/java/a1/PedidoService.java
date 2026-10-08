package a1;

public class PedidoService {
    private final EmailService emailService;
    private final EstoqueService estoqueService;

    public PedidoService(EmailService emailService, EstoqueService estoqueService) {
        this.emailService = emailService;
        this.estoqueService = estoqueService;
    }

    public String finalizarPedido(String cliente, String produto, int quantidade) {
        if (!estoqueService.verificarEstoque(produto, quantidade)) {
            return "sem_estoque";
        }
        boolean enviado = emailService.enviarEmail(cliente, "Pedido finalizado: " + produto);
        return enviado ? "sucesso" : "falhou";
    }
}
