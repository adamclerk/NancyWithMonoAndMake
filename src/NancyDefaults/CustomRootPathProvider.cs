using System;
using System.IO;
using Nancy;

namespace SampleOSX.Defaults
{
    public class CustomRootPathProvider : IRootPathProvider
    {
        public string GetRootPath()
        {
            var dir = Directory.GetCurrentDirectory() + "/src";
            //Console.WriteLine("Custom RootPath: " + dir);
            return dir;
        }
    }
}
