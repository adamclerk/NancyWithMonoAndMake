using System;
using Nancy;

namespace Module.Marketing
{
    public class MarketingModule : NancyModule
    {
        public MarketingModule()
        {
            Get["/"] = _ => View["index"];
        }
    }
}
