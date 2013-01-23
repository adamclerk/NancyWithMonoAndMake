using System;
using Nancy;
using Nancy.Bootstrapper;

namespace SampleOSX
{

    public class SiteHostApplicationStartup : IApplicationStartup
    {
        public void Initialize(IPipelines pipelines)
        {
            pipelines.BeforeRequest += ctx => {
                var reqDate = DateTime.Now;
                var requestId = Guid.NewGuid().ToString();
                var smallReqId = requestId.Substring(0,5);                
                ctx.Items.Add("req_id", smallReqId);
                ctx.Items.Add("req_date", reqDate);

                return null;
            };

            pipelines.AfterRequest += ctx => {
                var smallReqId = "0000";
                var reqStartDate = DateTime.Now;
                
                if(ctx.Items.ContainsKey("req_id"))
                    smallReqId = ctx.Items["req_id"].ToString();

                if(ctx.Items.ContainsKey("req_date"))
                    reqStartDate = (DateTime)ctx.Items["req_date"];
                
                //Static File was handled by static convention and doesnt have reqId
                if(smallReqId == "0000")
                    return;

                var reqFinDate = DateTime.Now;
                var reqSpan = (TimeSpan)(reqFinDate - reqStartDate);
                Console.WriteLine("Request: " + smallReqId);
                Console.WriteLine("-----------------------");
                Console.WriteLine(smallReqId + " - " + ctx.Response.StatusCode);
                Console.WriteLine(smallReqId + " - " + reqStartDate);
                Console.WriteLine(smallReqId + " - " + ctx.Request.Url);
                Console.WriteLine(smallReqId + " - " + reqSpan.TotalMilliseconds + "MS");
                Console.WriteLine("-----------------------");
            };

            pipelines.OnError += (ctx,ex) => {
                Console.WriteLine("++++++++ ERROR ++++++++");
                Console.WriteLine(ex);
                Console.WriteLine("++++++ END ERROR ++++++");

                return null;
            };
            return;
        }
    }
}
