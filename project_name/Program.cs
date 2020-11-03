using System;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;

namespace project_name
{
	class Program
	{
		[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
		[return: MarshalAs(UnmanagedType.Bool)]
		static extern bool SetDefaultDllDirectories(int directoryFlags);

		[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
		static extern void AddDllDirectory(string lpPathName);

		[DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
		[return: MarshalAs(UnmanagedType.Bool)]
		static extern bool SetDllDirectory(string lpPathName);

		const int LOAD_LIBRARY_SEARCH_DEFAULT_DIRS = 0x00001000;

		public static void Main(string[] args)
		{
			NativeLibrary.SetDllImportResolver(typeof(Microsoft.Xna.Framework.Color).Assembly, ImportResolver);

			if (Environment.OSVersion.Platform == PlatformID.Win32NT)
			{
				try
				{
					SetDefaultDllDirectories(LOAD_LIBRARY_SEARCH_DEFAULT_DIRS);
					AddDllDirectory(Path.Combine(
						AppDomain.CurrentDomain.BaseDirectory,
						Environment.Is64BitProcess ? "x64" : "x86"
					));
				}
				catch
				{
					// Pre-Windows 7, KB2533623
					SetDllDirectory(Path.Combine(
						AppDomain.CurrentDomain.BaseDirectory,
						Environment.Is64BitProcess ? "x64" : "x86"
					));
				}
			}

			using (Game1 game = new Game1())
			{
				game.Run();
			}
		}

		private static IntPtr ImportResolver(string libraryName, Assembly assembly, DllImportSearchPath? searchPath)
		{
			IntPtr libHandle = IntPtr.Zero;
			if (libraryName == "FNA3D")
			{
                if (Environment.OSVersion.Platform == PlatformID.Win32NT)
                    NativeLibrary.TryLoad("bin/Debug/x64/FNA3D.dll", assembly, DllImportSearchPath.System32, out libHandle);
                else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
				    NativeLibrary.TryLoad("bin/Debug/osx/libFNA3D.0.dylib", assembly, DllImportSearchPath.System32, out libHandle);
                else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                    NativeLibrary.TryLoad("bin/Debug/lib64/libFNA3D.so.0", assembly, DllImportSearchPath.System32, out libHandle);
			}
			else if (libraryName == "SDL2")
			{
                if (Environment.OSVersion.Platform == PlatformID.Win32NT)
                    NativeLibrary.TryLoad("bin/Debug/x64/SDL2.dll", assembly, DllImportSearchPath.System32, out libHandle);
                else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
				    NativeLibrary.TryLoad("bin/Debug/osx/libSDL2-2.0.0.dylib", assembly, DllImportSearchPath.System32, out libHandle);
                else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
                    NativeLibrary.TryLoad("bin/Debug/lib64/libSDL2-2.0.0.so.0", assembly, DllImportSearchPath.System32, out libHandle);
			}
            else
            {
                Console.WriteLine($"----- no case for library load: {libraryName} ---------");
            }

			return libHandle;
		}
	}
}
