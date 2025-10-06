using UnityEngine;

public class SuperBrain : AdvancedBrain
{
    new private int counter;
    public override void Think()
    {
        base.Think();
        Debug.Log("Super brain");
        counter += 2;
        Debug.Log("Base Counter " + base.counter + " Super Counter " + this.counter + " Base Counter " + base.Counter);
    }
}
