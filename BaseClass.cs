using UnityEngine;

public abstract class BaseClass : MonoBehaviour
{
    [SerializeField] protected int thoughtCount;

    // Start/Update are done through reflection, not inheritance
    void Start()
    {
        Initialize();
    }
    protected abstract void Initialize();
    void Update()
    {
        Think();
    }

    protected virtual void Think()
    {
        thoughtCount++;        
    }
}
