using System;
using System.Configuration;
using Nancy;
using Nancy.Diagnostics;
using Nancy.Bootstrapper;
using Nancy.TinyIoc;
using Nancy.Conventions;

namespace Site
{
    public class CustomBootstrapper : DefaultNancyBootstrapper
    {
        protected override DiagnosticsConfiguration DiagnosticsConfiguration
        {
            get
            {
                string pass = "password";
                return new DiagnosticsConfiguration {Password = pass};
            }
        }

        protected override Type RootPathProvider
        {
            get {return typeof(CustomRootPathProvider);}
        }

        protected override void ConfigureConventions(NancyConventions conventions)
        {
            base.ConfigureConventions(conventions);
            #if DEBUG
            StaticConfiguration.DisableErrorTraces = false;
            StaticConfiguration.DisableCaches = true;
            #endif
            conventions.StaticContentsConventions.Add(StaticContentConventionBuilder.AddDirectory("/css","/Content/css"));
            conventions.StaticContentsConventions.Add(StaticContentConventionBuilder.AddDirectory("/js", "/Content/js"));
            conventions.StaticContentsConventions.Add(StaticContentConventionBuilder.AddDirectory("/img", "/Content/img"));
        }

        protected override void ApplicationStartup(TinyIoCContainer container, IPipelines pipelines)
        {
            this.Conventions.ViewLocationConventions.Add((viewName, model, context) => {
                return string.Concat("Views/", viewName);
            });
        }

        protected override void RequestStartup(TinyIoCContainer requestContainer, IPipelines pipelines, NancyContext context)
        { 
        }
    }
}