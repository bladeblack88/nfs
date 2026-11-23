using UnityEngine;

namespace MostWantedMobile.Vehicle
{
    /// <summary>
    /// Lightweight arcade controller built around Unity WheelColliders.
    /// Assign the four wheel colliders and their visual wheel transforms in the Inspector.
    /// </summary>
    [RequireComponent(typeof(Rigidbody))]
    public sealed class ArcadeCarController : MonoBehaviour
    {
        [Header("Wheel colliders")]
        [SerializeField] private WheelCollider frontLeft;
        [SerializeField] private WheelCollider frontRight;
        [SerializeField] private WheelCollider rearLeft;
        [SerializeField] private WheelCollider rearRight;

        [Header("Wheel visuals")]
        [SerializeField] private Transform frontLeftVisual;
        [SerializeField] private Transform frontRightVisual;
        [SerializeField] private Transform rearLeftVisual;
        [SerializeField] private Transform rearRightVisual;

        [Header("Driving")]
        [SerializeField, Min(0f)] private float motorTorque = 1500f;
        [SerializeField, Min(0f)] private float brakeTorque = 3000f;
        [SerializeField, Min(0f)] private float maxSpeedKph = 180f;
        [SerializeField, Range(10f, 45f)] private float maxSteerAngle = 30f;
        [SerializeField, Range(0f, 1f)] private float steeringAtSpeed = 0.45f;
        [SerializeField] private bool frontWheelDrive;

        private Rigidbody body;
        private float throttleInput;
        private float steeringInput;
        private bool braking;

        public float SpeedKph => body == null ? 0f : body.linearVelocity.magnitude * 3.6f;

        private void Awake()
        {
            body = GetComponent<Rigidbody>();
            body.centerOfMass = new Vector3(0f, -0.45f, 0f);
        }

        private void Update()
        {
            // Keyboard fallback is useful while testing in the Unity Editor.
            if (Application.isEditor)
            {
                throttleInput = Input.GetAxisRaw("Vertical");
                steeringInput = Input.GetAxisRaw("Horizontal");
                braking = Input.GetKey(KeyCode.Space);
            }

            UpdateWheelVisual(frontLeft, frontLeftVisual);
            UpdateWheelVisual(frontRight, frontRightVisual);
            UpdateWheelVisual(rearLeft, rearLeftVisual);
            UpdateWheelVisual(rearRight, rearRightVisual);
        }

        private void FixedUpdate()
        {
            float speedFactor = Mathf.InverseLerp(0f, maxSpeedKph, SpeedKph);
            float steerLimit = maxSteerAngle * Mathf.Lerp(1f, steeringAtSpeed, speedFactor);
            float steer = steeringInput * steerLimit;

            if (frontLeft != null) frontLeft.steerAngle = steer;
            if (frontRight != null) frontRight.steerAngle = steer;

            float torque = SpeedKph < maxSpeedKph || throttleInput < 0f
                ? throttleInput * motorTorque
                : 0f;

            ApplyMotorTorque(torque);
            ApplyBrake(braking ? brakeTorque : 0f);
        }

        private void ApplyMotorTorque(float torque)
        {
            if (frontWheelDrive)
            {
                if (frontLeft != null) frontLeft.motorTorque = torque;
                if (frontRight != null) frontRight.motorTorque = torque;
            }
            else
            {
                if (rearLeft != null) rearLeft.motorTorque = torque;
                if (rearRight != null) rearRight.motorTorque = torque;
            }
        }

        private void ApplyBrake(float torque)
        {
            SetBrake(frontLeft, torque);
            SetBrake(frontRight, torque);
            SetBrake(rearLeft, torque);
            SetBrake(rearRight, torque);
        }

        private static void SetBrake(WheelCollider wheel, float torque)
        {
            if (wheel != null) wheel.brakeTorque = torque;
        }

        private static void UpdateWheelVisual(WheelCollider wheel, Transform visual)
        {
            if (wheel == null || visual == null) return;

            wheel.GetWorldPose(out Vector3 position, out Quaternion rotation);
            visual.SetPositionAndRotation(position, rotation);
        }

        public void SetThrottle(float value) => throttleInput = Mathf.Clamp(value, -1f, 1f);
        public void SetSteering(float value) => steeringInput = Mathf.Clamp(value, -1f, 1f);
        public void SetBraking(bool value) => braking = value;

        public void ResetInputs()
        {
            throttleInput = 0f;
            steeringInput = 0f;
            braking = false;
        }
    }
}
