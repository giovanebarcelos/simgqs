package a1;

public class EstoqueService {
    // Em produção faria consulta à base; aqui é "dummy"
    public boolean verificarEstoque(String produto, int quantidade) {
        if ("SKU-OUT".equals(produto)) return false;
        return quantidade <= 10;
    }
}
