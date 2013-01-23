using System;

namespace HtmlHelpers
{
    public static class Img
    {
        public static string Gravatar(string hash)
        {
        	return string.Format("<img class='thumbnail'  src='http://www.gravatar.com/avatar/{0}'>", hash);
        }
    }
}
