{
  ############################################
  ## Framework 16 hardware
  ############################################

  # MT7922 (RZ616) drops off the bus on resume unless ASPM is disabled.
  boot.extraModprobeConfig = ''
    options mt7921e disable_aspm=1
  '';
}