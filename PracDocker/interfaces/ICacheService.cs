public interface ICacheService<T>
{
    Task<T> Get(Guid id);
    Task Set(T content);
}
