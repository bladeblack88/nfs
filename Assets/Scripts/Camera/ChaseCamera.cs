using UnityEngine;

namespace MostWantedMobile.CameraSystem
{
    /// <summary>Spring-like chase camera for the prototype vehicle.</summary>
    public sealed class ChaseCamera : MonoBehaviour
    {
        [SerializeField] private Transform target;
        [SerializeField, Min(0.1f)] private float distance = 7.5f;
        [SerializeField, Min(0.1f)] private float height = 3.2f;
        [SerializeField, Min(0.1f)] private float positionSmooth = 6f;
        [SerializeField, Min(0.1f)] private float rotationSmooth = 8f;
        [SerializeField] private Vector3 lookOffset = new Vector3(0f, 1f, 0f);

        public void SetTarget(Transform newTarget) => target = newTarget;

        private void LateUpdate()
        {
            if (target == null) return;

            Vector3 desiredPosition = target.position
                - target.forward * distance
                + Vector3.up * height;

            transform.position = Vector3.Lerp(
                transform.position, desiredPosition,
                1f - Mathf.Exp(-positionSmooth * Time.deltaTime));

            Quaternion desiredRotation = Quaternion.LookRotation(
                target.position + lookOffset - transform.position,
                Vector3.up);

            transform.rotation = Quaternion.Slerp(
                transform.rotation, desiredRotation,
                1f - Mathf.Exp(-rotationSmooth * Time.deltaTime));
        }
    }
}