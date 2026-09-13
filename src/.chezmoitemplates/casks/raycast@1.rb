cask "raycast@1" do
  arch arm: "arm", intel: "x86_64"

  version "1.104.29"
  sha256 arm:   "1f098dce15ca1f678dd31fd3782dc8072d9104fb344af3ae753f84a66d97d15c",
         intel: "7360a3b0089f19c866b9602989e05e5d70ec7f7441111322720346ec94ec8c74"

  url "https://releases.raycast.com/releases/#{version}/download?build=#{arch}"
  name "Raycast"
  desc "Control your tools with a few keystrokes"
  homepage "https://raycast.com/"

  # Raycast 2 is Tahoe-only and homebrew/cask serves it to anything on Tahoe or
  # newer; this holds the last 1.x release, which still runs there.
  livecheck do
    skip "Held at the last 1.x release"
  end

  auto_updates true
  depends_on :macos

  app "Raycast.app"

  uninstall quit:       "com.raycast.macos",
            login_item: "Raycast"
end
