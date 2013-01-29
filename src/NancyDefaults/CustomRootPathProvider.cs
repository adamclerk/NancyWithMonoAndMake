using System;
using System.IO;
using Nancy;

namespace Site
{
	public class CustomRootPathProvider : IRootPathProvider
	{
	    public string GetRootPath()
	    {
	        var dir = Directory.GetCurrentDirectory() + "/src";
	        return dir;
	    }
	}
}