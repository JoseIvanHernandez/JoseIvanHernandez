using UnityEngine;

public class DerivedClass : BaseClass
{
    protected override void Initialize()
    {
        Debug.Log("Derived Initialized");
    }
    protected override void Think()
    {
        base.Think();
        
        if ((thoughtCount % 400) == 0)
        {
            Debug.Log("Thought 400 Times");
        }
    }

}
