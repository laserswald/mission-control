{
	inputs.nixpkgs.url = github:NixOS/nixpkgs;
	inputs.flake-utils.url = github:numtide/flake-utils;

	outputs = {self, nixpkgs, flake-utils}:
	  flake-utils.lib.eachDefaultSystem (system:
	    let
	        pkgs = nixpkgs.legacyPackages.${system};
	        runtimeDeps = [
		        pkgs.gauche
	        ];
	    in {
		    devShells.default = pkgs.mkShell {
			    buildInputs = runtimeDeps;
		    };
	    });
}
