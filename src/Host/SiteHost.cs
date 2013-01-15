using System;
using System.Linq;
using System.Threading;
using Model;
using Module;
using Helper;
using Nancy.Hosting.Self;

namespace SampleOSX
{
    class MainClass
    {
        public static void Main (string[] args)
        {
            // initialize an instance of NancyHost (found in the Nancy.Hosting.Self package)
            var url = "http://localhost:4002";
            var host = new NancyHost(new Uri(url));    
            host.Start();  // start hosting
            Console.WriteLine("Starting Site: " + url);

            //Under mono if you deamonize a process a Console.ReadLine with cause an EOF 
            //so we need to block another way
            if(args.Any(s => s.Equals("-d", StringComparison.CurrentCultureIgnoreCase)))
            {
                while(true) Thread.Sleep(10000000); 
            }
            else
            {
                Console.ReadKey();    
            }
            
            host.Stop();  // stop hosting
            Console.WriteLine("Stopping Site");
        }
    }
}
