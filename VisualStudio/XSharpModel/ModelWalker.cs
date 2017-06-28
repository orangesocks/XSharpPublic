﻿//
// Copyright (c) XSharp B.V.  All Rights Reserved.  
// Licensed under the Apache License, Version 2.0.  
// See License.txt in the project root for license information.
//
using LanguageService.CodeAnalysis.XSharp.SyntaxParser;
using LanguageService.SyntaxTree;
using LanguageService.SyntaxTree.Misc;
using LanguageService.SyntaxTree.Tree;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Collections.Concurrent;

namespace XSharpModel
{
    public class ModelWalker
    {
        static ModelWalker _walker;
        static int suspendLevel;
        static ModelWalker()
        { 
            suspendLevel = 0;
        }

        public static void Suspend()
        {
            suspendLevel += 1;
        }
        public static void Resume()
        {
            suspendLevel -= 1;

        }
        static public ModelWalker GetWalker()
        {
            if (_walker == null)
                _walker = new ModelWalker();
            return _walker;
        }

        private ConcurrentQueue<XProject> _projects;
        private Thread _WalkerThread;
        private ModelWalker()
        {
            _projects = new ConcurrentQueue<XProject>();
        }

        internal void AddProject(XProject xProject)
        {
            lock (this)
            {
                bool lAdd2Queue = true;
                foreach (var prj in _projects)
                {
                    if (String.Equals(prj.Name, xProject.Name, StringComparison.OrdinalIgnoreCase))
                    {
                        lAdd2Queue = false;
                        break;
                    }
                }
                if (lAdd2Queue)
                {
                    _projects.Enqueue(xProject);
                }
                if (!IsWalkerRunning)
                {
                    Walk();
                }
            }
        }


        public bool IsWalkerRunning
        {
            get
            {
                try
                {
                    if (_WalkerThread == null)
                        return false;
                    return _WalkerThread.IsAlive;
                }
                catch (Exception e)
                {
                    Support.Debug("Cannot check Background walker Thread : ");
                    Support.Debug(e.Message);
                }
                return false;

            }
        }
        public bool HasWork => _projects.Count > 0;
        public void Walk()
        {
            if (suspendLevel != 0)
                return;
            try
            {
                StopThread();
                ThreadStart ts = new ThreadStart(this.Walker);
                _WalkerThread = new Thread(ts);
                _WalkerThread.IsBackground = true;
                _WalkerThread.Priority = ThreadPriority.Highest;
                _WalkerThread.Name = "ModelWalker";
                _WalkerThread.Start();
            }
            catch (Exception e)
            {
                Support.Debug("Cannot start Background walker Thread : ");
                Support.Debug(e.Message);
            }
            return;
        }

        private void Walker()
        {
            XProject project = null;
            //
            do
            {
                if (suspendLevel != 0)
                {
                    // Abort and put project back in the list
                    if (project != null)
                    { 
                        _projects.Enqueue(project);
                    }
                    break;
                }
                // 
                lock (this)
                {
                    // need to continue ?
                    if (_projects.Count == 0)
                    {
                        break;
                    }
                    if (! _projects.TryDequeue( out project))
                    {
                        break;
                    }
                    project.ProjectNode.SetStatusBarText($"Start scanning project {project.Name}");
                    //
                }
                var aFiles = project.Files.ToArray();
                int iProcessed = 0;
                var options = new ParallelOptions ();
				if (System.Environment.ProcessorCount > 1)
				{
					options.MaxDegreeOfParallelism = (System.Environment.ProcessorCount * 3)/ 4;
				}
                project.ProjectNode.SetStatusBarAnimation(true, 0);
                Parallel.ForEach(aFiles, options, file =>
                {
                    // Detect project unload
                    if (project.Loaded)
                    {
                        iProcessed += 1;
                        project.ProjectNode.SetStatusBarText(String.Format("Walking {0} : Processing File {1} ({2} of {3})", project.Name, file.Name, iProcessed, aFiles.Length));
                        FileWalk(file);
                    }
                });
                project.ProjectNode.SetStatusBarText("");
                project.ProjectNode.SetStatusBarAnimation(false, 0);
            } while (true);
        }

        internal void FileWalk( XFile file )
        {
            DateTime dt = System.IO.File.GetLastWriteTime(file.FullPath);
            if (dt > file.LastWritten)
            {
                SourceWalker sw = new SourceWalker(file);
                //
                try
                {
                    var xTree = sw.Parse();
                    sw.BuildModel(xTree, false);
                    file.LastWritten= dt;
                    //
                }
                catch (Exception)
                {
                    // Push Exception away...
                    ;
                }
            }
        }

        internal void StopThread()
        {
            try
            {
                if (_WalkerThread == null)
                    return;
                if (_WalkerThread.IsAlive)
                {
                    _WalkerThread.Abort();
                }
            }
            catch (Exception e)
            {
                Support.Debug("Cannot stop Background walker Thread : ");
                Support.Debug(e.Message);
            }
            _WalkerThread = null;
            return;
        }
    }


}
