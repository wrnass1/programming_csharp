using PracDocker.Data;
using PracDocker.Models;
using PracDocker.Services.Interfaces;


public class ProductService : IProductService
{
    private readonly AppDbContext _context;
    private readonly ICacheService<Product> _cacheService;
    public ProductService(AppDbContext context, ICacheService<Product> cacheService)
    {
        _context = context;
        _cacheService = cacheService;
    }

    public async Task<Product> GetProduct(Guid id)
    {
        var product = await _cacheService.Get(id);
        if (product is not null)
        {
            return product;
        }
        product = await _context.Products.FindAsync(id) 
            ?? throw new Exception("Product not found");
        await _cacheService.Set(product);
        return product;
    }
}
