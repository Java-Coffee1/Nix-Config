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

  models = {
    inherit (mlModels)
      qwen-heretic
      gpt-oss-derestricted
      ;
  };

in
{
  services.llama-cpp = {
    enable = true;

    # nixpkgs builds llama.cpp with AVX turned off, so turn on what the Xeon Gold 6130 has
    package = pkgs.llama-cpp.overrideAttrs (old: {
      cmakeFlags = old.cmakeFlags ++ [
        (lib.cmakeBool "GGML_SSE42" true)
        (lib.cmakeBool "GGML_AVX" true)
        (lib.cmakeBool "GGML_AVX2" true)
        (lib.cmakeBool "GGML_FMA" true)
        (lib.cmakeBool "GGML_F16C" true)
        (lib.cmakeBool "GGML_BMI2" true)
        (lib.cmakeBool "GGML_AVX512" true)
      ];
    });

    modelsPreset = models;

    host = "127.0.0.1";
    port = 8080;
    openFirewall = false;

    extraFlags = [
      "--numa"
      "distribute"
      "-t"
      "32"
      "-c"
      "32768"
      "--models-max"
      "2"
      "--mlock"
    ];
  };

  # let llama.cpp lock the models in RAM (systemd only allows 8M by default)
  systemd.services.llama-cpp.serviceConfig.LimitMEMLOCK = "infinity";
}