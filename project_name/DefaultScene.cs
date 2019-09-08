using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Nez;
using Nez.ImGuiTools;

namespace project_name
{
    public class DefaultScene : Scene
    {
        public override void Initialize()
        {
            SetDesignResolution(Screen.Width, Screen.Height, Scene.SceneResolutionPolicy.None);

            AddRenderer(new DefaultRenderer());

            CreateEntity("demo imgui draw commands")
                .SetPosition(new Vector2(150, 150))
                .AddComponent<DemoComponent>()
                .AddComponent(new PrototypeSprite(20, 20));

            var Logo = Content.Load<Texture2D>("nez-logo-black");
            CreateEntity("logo")
                .SetPosition(Screen.Center)
                .AddComponent(new Nez.Sprites.Sprite(Logo));
        }
    }
}
