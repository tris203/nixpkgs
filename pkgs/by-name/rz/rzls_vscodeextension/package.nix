{
  lib,
  fetchFromGitHub,
  buildDotnetModule,
  dotnetCorePackages,
  jq,
}:
let
  pname = "rzls_vscodeextension";
  dotnet-sdk = dotnetCorePackages.sdk_9_0;
  dotnet-runtime = dotnetCorePackages.sdk_9_0;

in
buildDotnetModule {
  inherit pname dotnet-sdk dotnet-runtime;

  src = fetchFromGitHub {
    owner = "dotnet";
    repo = "razor";
    rev = "9ab78c78721106dcf827e397ff71b07114577712";
    hash = "sha256-ank/7cg5qubP9oAbj14WZtJ81nNKDh6g8FRVbkdUQAQ=";
  };

  version = "10.0.0-preview.25411.5";
  projectFile = "src/Razor/src/Microsoft.VisualStudioCode.RazorExtension/Microsoft.VisualStudioCode.RazorExtension.csproj";
  useDotnetFromEnv = true;
  nugetDeps = ./deps.json;

  nativeBuildInputs = [ jq ];

  postPatch = ''
    # Upstream uses rollForward = latestPatch, which pins to an *exact* .NET SDK version.
    jq '.sdk.rollForward = "latestMinor"' < global.json > global.json.tmp
    mv global.json.tmp global.json
  '';

  dotnetFlags = [
    # this removes the Microsoft.WindowsDesktop.App.Ref dependency
    "-p:EnableWindowsTargeting=false"
    "-p:PublishReadyToRun=false"
    "-p:NetVSCode=net9.0"
    "-p:DotNetUseShippingVersions=true"
  ];

  dotnetInstallFlags = [
    "-p:InformationalVersion=$version"
  ];

  meta = {
    homepage = "https://github.com/dotnet/razor";
    description = "Extension for Roslyn Language Server to provide Razor support in Visual Studio Code";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [
      tris203
    ];
    mainProgram = "Microsoft.VisualStudioCode.RazorExtension";
  };
}
