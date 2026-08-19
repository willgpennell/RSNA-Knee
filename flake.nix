{
  description = "RSNA Knee dev environment (ipynb development in VS Code)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        pythonEnv = pkgs.python313.withPackages (ps: with ps; [
          numpy
          pandas
          pydicom
          pillow
          matplotlib
          scikit-learn
          jupyter
          ipykernel
        ]);

        kernelName = "rsna-knee";
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ pythonEnv ];

          shellHook = ''
            # Register/refresh a persistent Jupyter kernelspec pointing at this
            # nix-built Python so the VS Code Jupyter extension can find it
            # even from outside an active `nix develop` shell.
            ${pythonEnv}/bin/python -m ipykernel install --user \
              --name "${kernelName}" \
              --display-name "Python (${kernelName} nix)" >/dev/null

            echo "RSNA Knee dev shell ready. In VS Code, select kernel:"
            echo "  Python (${kernelName} nix)"
          '';
        };
      });
}
