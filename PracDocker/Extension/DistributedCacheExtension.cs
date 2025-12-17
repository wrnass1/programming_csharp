using Microsoft.Extensions.Caching.Distributed;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

using Microsoft.Extensions.Caching.StackExchangeRedis;

namespace PracDocker.Extensions
{
    public static class DistributedCacheExtension
    {
        public static IServiceCollection AddDistributedCache(
            this IServiceCollection services,
            IConfiguration configuration)
        {
            var redisConnectionString = configuration.GetValue<string>("RedisConnectionString")
                ?? configuration.GetConnectionString("RedisConnectionString")
                ?? "localhost:6379";
            
            services.AddStackExchangeRedisCache(options =>
            {
                options.Configuration = redisConnectionString;
                options.InstanceName = "PracDocker_";
            });

            return services;
        }
    }
}
