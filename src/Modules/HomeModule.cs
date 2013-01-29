using System;
using System.Configuration;
using System.Dynamic;
using Nancy;

namespace Site
{
    public class HomeModule : NancyModule
    {
        public HomeModule()
        {
            Get["/"] = _ => {
            	dynamic model = new ExpandoObject();
            	model.GravatarHash = ConfigurationManager.AppSettings["GravatarHash"];
            	model.User = new User(){FirstName = "Adam", LastName="Clarke"};
            	return View["index", model];
            };
        }
    }
}