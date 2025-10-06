using UnityEngine;

public class Character
{
    private int health;
    public int Health
    {
        get
        {
            return health;
        }
        set
        {
            health = value;
            Debug.Log("Health set to: " + health);
        }
    }
    public Character() { }
}
