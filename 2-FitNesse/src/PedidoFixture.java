import a1.EmailService;
import a1.EstoqueService;
import a1.PedidoService;

public class PedidoFixture {
    private PedidoService pedidoService;
    private EmailService emailService;
    private EstoqueService estoqueService;
    private String cliente;
    private String produto;
    private int quantidade;
    private String resultado;

    public PedidoFixture() {
        this.emailService = new EmailService();
        this.estoqueService = new EstoqueService();
        this.pedidoService = new PedidoService(emailService, estoqueService);
    }

    public void setCliente(String cliente) {
        this.cliente = cliente;
    }

    public void setProduto(String produto) {
        this.produto = produto;
    }

    public void setQuantidade(int quantidade) {
        this.quantidade = quantidade;
    }

    public String finalizarPedido() {
        this.resultado = pedidoService.finalizarPedido(cliente, produto, quantidade);
        return resultado;
    }

    public String getResultado() {
        return resultado;
    }
}
