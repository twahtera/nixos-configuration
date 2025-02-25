{
  description = "Nixos configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, ... }@inputs: {

    nixosConfigurations.furikawari = nixpkgs.lib.nixosSystem {
      system = "x86_64-GNU/Linux";
      modules = [
        ./furikawari/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.backupFileExtension = "backup";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.twah = import ./home.nix;
        
          home.username = "twah";
          home.homeDirectory = "/home/twah";
        }
      ];
    };

    nixosConfigurations.sabaki = nixpkgs.lib.nixosSystem {
      system = "x86_64-GNU/Linux";
      modules = [
        ./sabaki/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.backupFileExtension = "backup";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.twah = import ./home.nix {username = "ent";}
        }
      ];
    };
    
    nixosConfigurations.kaketsugi = nixpkgs.lib.nixosSystem {
      system = "x86_64-GNU/Linux";
      modules = [
        ./kaketsugi/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.backupFileExtension = "backup";
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.twah = import ./home.nix;
        
          home.username = "ent";
          home.homeDirectory = "/home/ent";
        }
      ];
    };
  };
}
