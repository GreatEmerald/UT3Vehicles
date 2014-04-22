//-----------------------------------------------------------
// UT3ScorpionInteraction.uc
// A 1337 way of speeding up and jumping out of the Scorpion
// 2009, GreatEmerald
//-----------------------------------------------------------
class UT3ScorpionInteraction extends Interaction;

//UNDONE !!GE: test to know if we actually record a key press.

function bool KeyEvent(EInputKey Key, EInputAction Action, FLOAT Delta )
{
        if (Action == IST_Press)
                ViewportOwner.Actor.ClientMessage("Key PRESSED:" @ Key);//GE: We need it to return IK_Space or 32
                                                                        //GE: First space for boost, the second for kamikaze

        return false;
}

//TODO !!GE: How to replicate this to the actual Scorpion code?
//GE: UT3Scorpion.GoToState('Ejecting'); or more likely UT3Scorpion.Boost

DefaultProperties
{
   bActive=true
}
