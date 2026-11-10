{ pkgs, lib, ... }:

let
  mlModels = {
    qwen-heretic = {
      hf-repo = "Youssofal/Qwen3.6-35B-A3B-Abliterated-Heretic-GGUF:Q4_K_M";
      load-on-startup = true;
    };

    gpt-oss-derestricted = {
      hf-repo = "Calandracas/gpt-oss-120b-Derestricted-GGUF:Q4_K_M";
      load-on-startup = true;
    };
  };

  models = { inherit (mlModels) qwen-heretic gpt-oss-derestricted; };

  # llama-server has no built-in flag to cap HF model-download speed, so throttle
  # it with trickle (userspace bandwidth shaper) instead - cap at 100 MiB/s to
  # leave headroom on a 275 MB/s line.
  # VM CPU type is set to "host" in Proxmox so the Xeon Gold 6130's AVX2/AVX512/FMA
  # are passed through - stock package picks them up, no SSE-only override needed
  llamaCppBase = pkgs.llama-cpp;

  downloadRateKiBs = 100 * 1024;

  llamaCppThrottled = pkgs.symlinkJoin {
    name = "llama-cpp-throttled";
    paths = [ llamaCppBase ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm $out/bin/llama-server
      makeWrapper ${pkgs.trickle}/bin/trickle $out/bin/llama-server \
        --add-flags "-s -d ${toString downloadRateKiBs} ${lib.getExe' llamaCppBase "llama-server"}"
    '';
  };

in
{
  services.llama-cpp = {
    enable = true;

    package = llamaCppThrottled;

    modelsPreset = models;

    host = "127.0.0.1";
    port = 8080;
    openFirewall = false;

    extraFlags = [
      "--numa"
      "distribute"
      "-t"
      "48"
      "--threads-batch"
      "48"
      "-c"
      "32768"
      "--models-max"
      "2"
      "--mlock"
      "--timeout"
      "10800"
    ];
  };

  # let llama.cpp lock the models in RAM (systemd only allows 8M by default)
  systemd.services.llama-cpp.serviceConfig.LimitMEMLOCK = "infinity";
}
