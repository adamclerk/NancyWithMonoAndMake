using System;
using System.Configuration;
using System.Dynamic;
using Nancy;
using Model;

namespace Module.Marketing
{
    public class HomeModule : NancyModule
    {
        public HomeModule()
        {
            Get["/"] = _ => {
            	dynamic model = new ExpandoObject();
            	model.GravatarHash = ConfigurationManager.AppSettings["GravatarHash"];
            	model.User = new User(){FirstName = "Adam", LastName="Clark"};
            	return View["index", model];
            };
        }
    }
}
