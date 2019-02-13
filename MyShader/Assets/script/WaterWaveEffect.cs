using UnityEngine;

public class WaterWaveEffect : PostEffectBase
{

    public float distanceFactor = 60.0f;
    public float timeFactor = -30.0f;
    public float totalFactor = 1.0f;

    public float waveWidth = 0.3f;
    public float waveSpeed = 0.3f;

    private float waveStartTime;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        float curWaveDistance = (Time.time - waveStartTime) * waveSpeed;
        _Material.SetFloat("_distanceFactor", distanceFactor);
        _Material.SetFloat("_timeFactor", timeFactor);
        _Material.SetFloat("_totalFactor", totalFactor);
        _Material.SetFloat("_waveWidth", waveWidth);
        _Material.SetFloat("_curWaveDis", curWaveDistance);

        Graphics.Blit(source, destination, _Material);
    }

    void OnEnable()
    {
        waveStartTime = Time.time;
    }
}
