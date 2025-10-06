using UnityEngine;

public class CharacterWrapper : MonoBehaviour
{
    [SerializeField] GameObject other;
    [SerializeField] int health;
    public int Health { get { return character.Health; } set { character.Health = value; } }
    Character character;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        character = new Character();
    }

    // Update is called once per frame
    void Update()
    {
        if (health != Health) { Health = health; }

        Vector3 toOther = other.transform.position - this.transform.position;
        Debug.Log("To Other: " + toOther);

        toOther.Normalize();

        float dot = Vector3.Dot(toOther, transform.forward);
        Debug.Log("Dot toOther and Forward " + dot);
    }
}
