using UnityEngine;
using MostWantedMobile.Vehicle;

namespace MostWantedMobile.Input
{
    /// <summary>
    /// Connect UI Button EventTrigger or pointer handlers to these public methods.
    /// Press methods set an input; release methods clear it.
    /// </summary>
    public sealed class MobileInputBridge : MonoBehaviour
    {
        [SerializeField] private ArcadeCarController car;

        public void GasPressed() { if (car != null) car.SetThrottle(1f); }
        public void GasReleased() { if (car != null) car.SetThrottle(0f); }

        public void ReversePressed() { if (car != null) car.SetThrottle(-1f); }
        public void ReverseReleased() { if (car != null) car.SetThrottle(0f); }

        public void LeftPressed() { if (car != null) car.SetSteering(-1f); }
        public void LeftReleased() { if (car != null) car.SetSteering(0f); }

        public void RightPressed() { if (car != null) car.SetSteering(1f); }
        public void RightReleased() { if (car != null) car.SetSteering(0f); }

        public void BrakePressed() { if (car != null) car.SetBraking(true); }
        public void BrakeReleased() { if (car != null) car.SetBraking(false); }

        public void ReleaseAll()
        {
            if (car != null) car.ResetInputs();
        }
    }
}
