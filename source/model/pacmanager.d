module model.pacmanager;

import core.sync.rwmutex;
import std.array : replace;
import std.conv;
import std.datetime.systime : SysTime;

import vibe.core.path : NativePath, relativeTo;

import model.entities.pac;
import model.model;
import model.pacbuilder : PACBuilder;

class PACManager
{
    this(Model model, in string dataDir)
    {
        m_model = model;
        m_pacBuilder = new PACBuilder(model);
        m_mutex = new ReadWriteMutex();
        m_dataDir = NativePath(dataDir);
        m_dataDir.normalize();
    }

    const(NativePath) getPACfilePath(in string servePath) @trusted
    {
        synchronized (m_mutex.reader)
        {
            auto pac = m_model.pacByServePath(servePath);
            auto desc = pac.id() in m_pacFiles;
            if (desc && desc.updatedAt >= pac.updatedAt())
            {
                return desc.filePath;
            }
        }

        // Use double-checked locking pattern here
        synchronized (m_mutex.writer)
        {
            auto pac = m_model.pacByServePath(servePath);
            auto desc = pac.id() in m_pacFiles;
            if (desc && desc.updatedAt >= pac.updatedAt())
            {
                return desc.filePath;
            }

            string pacContent = m_pacBuilder.build(pac.id());

            NativePath filePath = m_dataDir ~ NativePath("servecache/" ~ makeFileName(pac));
			File file = File(filePath.toString(), "w");
			file.write(pacContent);
			file.close();

            m_pacFiles[pac.id()] = PACDesc(filePath, pac.updatedAt());

            // TODO: remove old

            return filePath;
        }
    }

private:
    Model m_model;
    PACBuilder m_pacBuilder;
    NativePath m_dataDir;
    ReadWriteMutex m_mutex;
    PACDesc[long] m_pacFiles;
}

private struct PACDesc
{
    NativePath filePath;
    SysTime updatedAt;
}

private string makeFileName(in PAC pac) @safe
{
    auto ts = pac.updatedAt().toUTC().toISOExtString().replace(":", "-").replace(".", "_");
    return to!string(pac.id()) ~ "-" ~ ts ~ ".pac";
}