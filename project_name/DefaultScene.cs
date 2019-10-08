using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using Nez;
using Nez.Sprites;

namespace project_name
{
	public class DefaultScene : Scene
    {
        public override void Initialize()
        {
            SetDesignResolution(Screen.Width, Screen.Height, Scene.SceneResolutionPolicy.None);

            CreateEntity("demo imgui draw commands")
                .SetPosition(new Vector2(150, 150))
                .AddComponent<DemoComponent>()
                .AddComponent(new PrototypeSprite(20, 20));

            var logo = Content.LoadTexture("Textures/nez-logo-black");
            CreateEntity("logo")
                .SetPosition(Screen.Center)
                .AddComponent(new SpriteRenderer(logo));
        }
    }
}
