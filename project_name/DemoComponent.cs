using ImGuiNET;
using Nez;
using Nez.ImGuiTools;

namespace lucid
{
    public class DemoComponent : Component
    {
        int _buttonClickCounter;

        public override void onAddedToEntity()
        {
            // register with the ImGuiMangaer letting it know we want to render some IMGUI
#if DEBUG
            Core.getGlobalManager<ImGuiManager>().registerDrawCommand(imGuiDraw);
#endif
        }

        public override void onRemovedFromEntity()
        {
            // remove ourselves when we are removed from the Scene
#if DEBUG
            Core.getGlobalManager<ImGuiManager>().unregisterDrawCommand(imGuiDraw);
#endif
        }

        void imGuiDraw()
        {
            // do your actual drawing here
            ImGui.Begin("Your ImGui Window", ImGuiWindowFlags.AlwaysAutoResize);
            ImGui.Text("This is being drawn in DemoComponent");
            if (ImGui.Button($"Clicked me {_buttonClickCounter} times"))
                _buttonClickCounter++;
            ImGui.End();
        }

    }
}

