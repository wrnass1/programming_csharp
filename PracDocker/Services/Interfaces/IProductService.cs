using PracDocker.Models;

public interface IProductService
{
    Task<Product> GetProduct(Guid id);
}
