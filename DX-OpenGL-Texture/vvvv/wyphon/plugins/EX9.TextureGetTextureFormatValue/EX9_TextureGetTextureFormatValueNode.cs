#region usings
using System;
using System.ComponentModel.Composition;

using SlimDX;
using SlimDX.Direct3D9;
using VVVV.Core.Logging;
using VVVV.PluginInterfaces.V1;
using VVVV.PluginInterfaces.V2;

#endregion usings

namespace VVVV.Nodes
{
	#region PluginInfo
	[PluginInfo(Name = "GetTextureFormatValue", Category = "EX9.Texture", Help = "Basic template which creates a texture", Tags = "")]
	#endregion PluginInfo
	public class EX9_TextureGetTextureFormatValueNode : IPluginEvaluate, IPartImportsSatisfiedNotification
	{

		[Input("Format", DefaultValue = 0)]
		ISpread<Format> InFormat;

		[Output("Format Value")]
		ISpread<int> outFormat;

		[Import()]
		ILogger FLogger;

		public void OnImportsSatisfied()
		{
			//spreads have a length of one by default, change it
			//to zero so ResizeAndDispose works properly.
		}

		//called when data for any output pin is requested
		public void Evaluate(int spreadMax)
		{
			outFormat[0] = (int) InFormat[0];
		}

	}
}
