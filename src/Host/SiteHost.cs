using System;
using System.Linq;
using System.Threading;
using Mono.Options;
using Nancy.Hosting.Self;


namespace Host
{
    class MainClass
    {
        public static void Main (string[] args)
        {
            var ep = "http://localhost:4001";
            var daemon = false;
            var help = false;

            var p = new OptionSet () {
                { "e|endpoint=", "endpoint of site. ("+ep+")", a => ep = a},
                { "d|daemon", "run as deamonized process", a => daemon = a != null},
                { "h|help", "show this message and exit", a => help = a != null}
            };

            try{
                p.Parse(args);
            }
            catch(OptionException e){
                Console.WriteLine("host.exe: ");
                Console.WriteLine(e.Message);
                Console.WriteLine("host.exe --help for more information.");
                return;
            }

            if(help)
            {
                ShowHelp(p);
                return;
            }

            // initialize an instance of NancyHost (found in the Nancy.Hosting.Self package)
            var host = new NancyHost(new Uri(ep));    
            host.Start();  // start hosting
            Console.WriteLine("Starting Site: " + ep);

            //Under mono if you deamonize a process a Console.ReadLine with cause an EOF 
            //so we need to block another way
            if(daemon)
            {
                while(true) Thread.Sleep(10000000); 
            }
            else
            {
                Console.ReadKey();    
            }

            host.Stop();
            Console.WriteLine("Stopping Site");
        }

        private static void ShowHelp(OptionSet p)
        {
            Console.WriteLine("Usage: host.exe [OPTIONS]");
            Console.WriteLine("Self running site!");
            Console.WriteLine();
            Console.WriteLine("Options:");
            p.WriteOptionDescriptions(Console.Out);
        }
    }
}
