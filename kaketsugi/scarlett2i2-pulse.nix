{ config, pkgs, ... }:
{
  services.pulseaudio.daemon.config =
    {
      high-priority = "yes";
      nice-level = "-15";
      flat-volumes = "no";
      rlimit-fsize = "-1";
      rlimit-data = "-1";
      rlimit-stack = "-1";
      rlimit-core = "-1";
      rlimit-as = "-1";
      rlimit-rss = "-1";
      rlimit-nproc = "-1";
      rlimit-nofile = "256";
      rlimit-memlock = "-1";
      rlimit-locks = "-1";
      rlimit-sigpending = "-1";
      rlimit-msgqueue = "-1";
      rlimit-nice = "31";
      rlimit-rtprio = "9";
      rlimit-rttime = "200000";

      default-sample-format = "s24le";
      default-sample-rate = "44100";
      #default-sample-rate = "96000";
      alternate-sample-rate = "44100";
      default-sample-channels = "2";
      default-channel-map = "front-left,front-right";
      default-fragments = "2";

      default-fragment-size-msec = "250";

      enable-deferred-volume = "yes";
      deferred-volume-safety-margin-usec = "1";
      deferred-volume-extra-delay-usec = "0";
    };
  services.pulseaudio.extraConfig = "load-module module-remap-sink sink_name=Scarlett_12 sink_properties=\"device.description='Scarlett Output 1/2 (Main)'\" remix=no master=alsa_output.usb-Focusrite_Scarlett_2i4_USB-00.analog-surround-40 channels=2 master_channel_map=front-left,front-right channel_map=front-left,front-right";
}
