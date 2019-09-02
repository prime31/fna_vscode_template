using Nez;
using Nez.ImGuiTools;

namespace project_name
{
    class Game1 : Core
    {
        public Game1() : base()
        {}

        override protected void Initialize()
        {
            base.Initialize();
			
#if DEBUG
            System.Diagnostics.Debug.Listeners.Add(new System.Diagnostics.TextWriterTraceListener(System.Console.Out));

             // render Nez in the imgui window in debug mode
			var imGuiManager = new ImGuiManager();
			Core.registerGlobalManager(imGuiManager);
#endif

            scene = new DefaultScene();
            
           
        }
    }
}