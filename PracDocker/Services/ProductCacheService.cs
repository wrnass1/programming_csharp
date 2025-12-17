using Microsoft.Extensions.Caching.Distributed;
using Newtonsoft.Json;
using PracDocker.Models;
using PracDocker.Services.Interfaces;

public class ProductCacheService : ICacheService<Product>
{
    private readonly IDistributedCache _distributedCache;
    private readonly DistributedCacheEntryOptions _options;
    private const string Prefix = "product_";

    public ProductCacheService(IDistributedCache distributedCache)
    {
        _distributedCache = distributedCache;
        _options = new DistributedCacheEntryOptions
        {
            AbsoluteExpirationRelativeToNow = 
                TimeSpan.FromSeconds(120),
            SlidingExpiration = TimeSpan.FromSeconds(60)
        };
    }

    public async Task<Product> Get(Guid id)
    {
        var key = Prefix + id;
        var cache = await _distributedCache.GetStringAsync(key);
        if (cache is null)
        {
            return null;
        }
        var product = JsonConvert.DeserializeObject<Product> 
            (cache);
        return product;
    }

    public async Task Set(Product content)
    {
        var key = Prefix + content.Id;
        var productString = JsonConvert.SerializeObject(content);
        await _distributedCache.SetStringAsync(key, productString, 
            _options);
    }
}