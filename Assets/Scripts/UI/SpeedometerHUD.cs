using UnityEngine;
using UnityEngine.UI;
using MostWantedMobile.Vehicle;

namespace MostWantedMobile.UI
{
    /// <summary>Displays vehicle speed using a legacy Unity UI Text element.</summary>
    public sealed class SpeedometerHUD : MonoBehaviour
    {
        [SerializeField] private ArcadeCarController vehicle;
        [SerializeField] private Text speedLabel;

        private void Update()
        {
            if (vehicle == null || speedLabel == null) return;
            speedLabel.text = Mathf.RoundToInt(vehicle.SpeedKph) + " KM/H";
        }

        public void SetVehicle(ArcadeCarController target) => vehicle = target;
        public void SetLabel(Text label) => speedLabel = label;
    }
}