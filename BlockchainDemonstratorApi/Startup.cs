using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using BlockchainDemonstratorApi.Data;
using BlockchainDemonstratorApi.Hubs;
using BlockchainDemonstratorApi.Models.Classes;
using Newtonsoft.Json.Serialization;
using System.IO;

namespace BlockchainDemonstratorApi
{
    public class Startup
    {
        readonly string BlockchainDemonstratorWebApp = "_blockchainDemonstratorWebApp";

        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddControllers().AddNewtonsoftJson(options =>
            {
                options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
                options.SerializerSettings.ContractResolver = new DefaultContractResolver();
            });

            services.AddDbContext<BeerGameContext>(options =>
                    options.UseSqlServer(Configuration.GetConnectionString("BeerGameContext")));

            services.AddCors(options =>
            {
                options.AddPolicy(name: BlockchainDemonstratorWebApp,
                    builder =>
                    {
                        // Development origins
                        builder.WithOrigins("https://localhost:44313").AllowAnyHeader()
                            .AllowAnyMethod().AllowCredentials();

                        // Production origins - based on ServerIp parameter
                        builder.WithOrigins("https://" + Config.ServerIp).AllowAnyHeader()
                            .AllowAnyMethod().AllowCredentials();
                        builder.WithOrigins("http://" + Config.ServerIp).AllowAnyHeader()
                            .AllowAnyMethod().AllowCredentials();

                        // Additional origins from environment variable (comma-separated)
                        var additionalOrigins = Environment.GetEnvironmentVariable("CORS_ORIGINS");
                        if (!string.IsNullOrEmpty(additionalOrigins))
                        {
                            foreach (var origin in additionalOrigins.Split(','))
                            {
                                builder.WithOrigins(origin.Trim()).AllowAnyHeader()
                                    .AllowAnyMethod().AllowCredentials();
                            }
                        }
                    });
            });
            
            services.AddSignalR().AddJsonProtocol(options => {
                options.PayloadSerializerOptions.PropertyNamingPolicy = null;
            });
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, BeerGameContext beerGameContext)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                string file = File.ReadAllText("appsettings.json");
                dynamic json = Newtonsoft.Json.JsonConvert.DeserializeObject(file);
                json["ConnectionStrings"]["BeerGameContext"] = "Server=127.0.0.1,1433;Database=BeerGameContext;Trusted_Connection=True;MultipleActiveResultSets=true;User id=sa;Password=B33rgam3;Integrated Security=false";
                string output = Newtonsoft.Json.JsonConvert.SerializeObject(json, Newtonsoft.Json.Formatting.Indented);
                File.WriteAllText("appsettings.json", output);
            }

            //app.UseHttpsRedirection();

            app.UseRouting();
            
            app.UseCors(BlockchainDemonstratorWebApp);

            SeedData.Initialize(beerGameContext);

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
                endpoints.MapHub<GameHub>("/GameHub");
            });
        }
    }
}
